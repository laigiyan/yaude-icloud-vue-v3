<template>
  <a-modal
    :title="title"
    :width="1000"
    :visible="visible"
    :confirmLoading="confirmLoading"
    @ok="handleOk"
    @cancel="handleCancel"
    cancelText="關閉">
    <a-spin :spinning="confirmLoading">
      <a-form-model ref="form"  :label-col="labelCol" :wrapper-col="wrapperCol"  :model="model" :rules="validatorRules">
        <a-row>
          <a-col :span="14" >
            <a-form-model-item label="規則" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="securityGroupRule">
              <j-dict-select-tag  :triggerChange="true" dictCode="security_group_rules"  v-model="model.securityGroupRule"  placeholder="請選擇規則">
              </j-dict-select-tag>
            </a-form-model-item>

            <!--<a-form-model-item label="描述" :labelCol="labelCol" :wrapperCol="wrapperCol"  >
              <a-textarea v-model="model.description" placeholder="請輸入描述" ></a-textarea>
            </a-form-model-item>-->

            <a-form-model-item label="方向" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="direction">
              <j-dict-select-tag  :triggerChange="true" dictCode="direction"  v-model="model.direction"  placeholder="請選擇方向">
              </j-dict-select-tag>
            </a-form-model-item>

            <a-form-model-item label="打開埠口" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="openPortType">
              <j-dict-select-tag  :triggerChange="true" dictCode="open_port_type"  v-model="model.openPortType" @change="changeOpenProtType"  placeholder="請選擇埠口管控方式">
              </j-dict-select-tag>
            </a-form-model-item>

            <a-form-model-item label="埠口號" v-show="showPort"  :labelCol="labelCol" :wrapperCol="wrapperCol">
              <a-input placeholder="請輸入埠口號" v-model="model.port"></a-input>
            </a-form-model-item>

            <a-form-model-item label="起始埠口號"  v-show="showPortRange" :labelCol="labelCol" :wrapperCol="wrapperCol">
              <a-input placeholder="請輸入起始埠口號"  v-model="model.portRangeMin"></a-input>
            </a-form-model-item>

            <a-form-model-item label="結束埠口號" v-show="showPortRange" :labelCol="labelCol" :wrapperCol="wrapperCol">
              <a-input placeholder="請輸入結束埠口號" v-model="model.portRangeMax"></a-input>
            </a-form-model-item>


            <a-form-model-item label="遙控" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="remoteType">
              <j-dict-select-tag  :triggerChange="true" dictCode="remote_type" @change="changeRemoteType"  v-model="model.remoteType"  placeholder="請選擇遙控">
              </j-dict-select-tag>
            </a-form-model-item>

            <a-form-model-item label="CIDR" v-show="showCIDR" :labelCol="labelCol" :wrapperCol="wrapperCol" >
              <a-input placeholder="請輸入路由標記" v-model="model.cidr"></a-input>
            </a-form-model-item>

            <a-form-model-item label="安全群組" v-show="showRemoteGroup" :labelCol="labelCol" :wrapperCol="wrapperCol">
              <a-select v-model="model.remoteGroupId"  placeholder="請選擇安全群組" >
                <a-select-option v-for="rgi in remoteGroupIds":value="rgi.value"  >{{rgi.text}}</a-select-option>
              </a-select>
            </a-form-model-item>

            <a-form-model-item label="以太網類型（EtherType）"  v-show="showRemoteGroup" :labelCol="labelCol" :wrapperCol="wrapperCol">
              <j-dict-select-tag  :triggerChange="true" dictCode="ether_type"  v-model="model.etherType"   placeholder="請選擇埠口管控方式">
              </j-dict-select-tag>
            </a-form-model-item>

          </a-col>

          <a-col :span="10" >
            <h1>說明</h1>
            <h4>實例可以關聯安全群組，組中的規則定義了允許哪些訪問到達被關聯的實例。安全群組由以下三個主要組件組成：</h4>
            <h4><b>規則：</b> 您可以指定期望的規則模板或者使用定制規則，選項有定制TCP規則、定制UDP規則或定制ICMP規則。</h4>
            <h4><b>打開埠口/埠口範圍：</b> 您選擇的TCP和UDP規則可能會打開一個或一組埠口.選擇"埠口範圍"，您需要提供開始和結束埠口的範圍.對於ICMP規則您需要指定ICMP類型和代碼.</h4>
            <h4><b>遙控：</b> 您必須指定允許通過該規則的流量來源。可以通過以下兩種方式實現：IP 位址塊(CIDR)或者來源地址組(安全群組)。如果選擇一個安全群組作為來訪源地址，則該安全群組中的任何實例都被允許使用該規則訪問任一其它實例。</h4>
          </a-col>




        </a-row>
      </a-form-model>
    </a-spin>
  </a-modal>
</template>

<script>
  import { getAction,httpAction } from '@/api/manage'

  export default {
    name: "SecurityGroupModalRule",
    props: {
      //表單禁用
      remoteGroupIds: {
        type: Array,
        default: ()=>[],
        required: false
      }
    },
    data () {
      return {
        title:"新增",
        visible: false,
        model: {},
        layout: {
          labelCol: { span: 3 },
          wrapperCol: { span: 14 },
        },
        labelCol: {
          xs: { span: 24 },
          sm: { span: 7 },
        },
        wrapperCol: {
          xs: { span: 24 },
          sm: { span: 15 },
        },
        confirmLoading: false,
        form: this.$form.createForm(this),
        validatorRules:{
          securityGroupRule: [
            { required: true, message: '請選擇規則!' },
          ],
          direction:[
            { required: true, message: '請選擇方向!' },
          ],
          openPortType:[
            { required: true, message: '請選擇打開埠口!' },
          ],
          remoteType:[
            { required: true, message: '請選擇遙控!' },
          ]
        },
        url: {
          add:"/openstack/securityGroup/createSecurityGroupRule",
        },
        showPort:true,
        showPortRange:false,
        showCIDR:false,
        showRemoteGroup:false,
      }
    },
    created () {

    },
    methods: {
      add (record) {
        this.edit(record);
      },
      edit (record) {
        this.model = Object.assign({}, record);
        this.visible = true;
      },
      close () {
        this.$refs.form.resetFields();
        this.$emit('close');
        this.visible = false;
      },
      handleOk () {
        const that = this;
        // 觸發表單驗證
        this.$refs.form.validate(valid => {
          if (valid) {
            that.confirmLoading = true;
            getAction(that.url.add,that.model).then((res)=>{
              if(res.success){
                that.$message.success(res.message);
                that.$emit('ok');
              }else{
                that.$message.warning(res.message);
              }
            }).finally(() => {
              that.confirmLoading = false;
              that.close();
            })
          }
        })
      },
      handleCancel () {
        this.close()
      },
      changeOpenProtType(value){
        if(value){
          if(value=="port"){ //埠口
            this.showPort = true;
            this.showPortRange = false;
          }else if(value=="portRange"){//埠口範圍
            this.showPort = false;
            this.showPortRange = true;
          }else if(value=="allPort"){//所有埠口
            this.showPort = false;
            this.showPortRange = false;
          }
        }else{
          this.showPort = true;
          this.showPortRange = false;
        }
      },
      changeRemoteType(value){
        if(value){
          if(value==1){ //CIDR
            this.showCIDR = true;
            this.model.cidr = "0.0.0.0/0";
            this.showRemoteGroup = false;
          }else if(value==2){//安全群組
            this.showCIDR = false;
            this.model.cidr = '';
            this.showRemoteGroup = true;
          }
        }else{
          this.showCIDR = false;
          this.showRemoteGroup = false;
        }
      }
    }
  }
</script>

<style scoped>

</style>