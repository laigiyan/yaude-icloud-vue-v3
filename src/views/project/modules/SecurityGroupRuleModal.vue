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

            <a-form-model-item label="打開端口" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="openPortType">
              <j-dict-select-tag  :triggerChange="true" dictCode="open_port_type"  v-model="model.openPortType" @change="changeOpenProtType"  placeholder="請選擇端口管控方式">
              </j-dict-select-tag>
            </a-form-model-item>

            <a-form-model-item label="端口號" v-show="showPort"  :labelCol="labelCol" :wrapperCol="wrapperCol">
              <a-input placeholder="請輸入端口號" v-model="model.port"></a-input>
            </a-form-model-item>

            <a-form-model-item label="起始端口號"  v-show="showPortRange" :labelCol="labelCol" :wrapperCol="wrapperCol">
              <a-input placeholder="請輸入起始端口號"  v-model="model.portRangeMin"></a-input>
            </a-form-model-item>

            <a-form-model-item label="結束端口號" v-show="showPortRange" :labelCol="labelCol" :wrapperCol="wrapperCol">
              <a-input placeholder="請輸入結束端口號" v-model="model.portRangeMax"></a-input>
            </a-form-model-item>


            <a-form-model-item label="遠程" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="remoteType">
              <j-dict-select-tag  :triggerChange="true" dictCode="remote_type" @change="changeRemoteType"  v-model="model.remoteType"  placeholder="請選擇遠程">
              </j-dict-select-tag>
            </a-form-model-item>

            <a-form-model-item label="CIDR" v-show="showCIDR" :labelCol="labelCol" :wrapperCol="wrapperCol" >
              <a-input placeholder="請輸入路由標記" v-model="model.cidr"></a-input>
            </a-form-model-item>

            <a-form-model-item label="安全組" v-show="showRemoteGroup" :labelCol="labelCol" :wrapperCol="wrapperCol">
              <a-select v-model="model.remoteGroupId"  placeholder="請選擇安全組" >
                <a-select-option v-for="rgi in remoteGroupIds":value="rgi.value"  >{{rgi.text}}</a-select-option>
              </a-select>
            </a-form-model-item>

            <a-form-model-item label="以太網類型（EtherType）"  v-show="showRemoteGroup" :labelCol="labelCol" :wrapperCol="wrapperCol">
              <j-dict-select-tag  :triggerChange="true" dictCode="ether_type"  v-model="model.etherType"   placeholder="請選擇端口管控方式">
              </j-dict-select-tag>
            </a-form-model-item>

          </a-col>

          <a-col :span="10" >
            <h1>說明</h1>
            <h4>實例可以關聯安全組，組中的規則定義了允許哪些訪問到達被關聯的實例。安全組由以下三個主要組件組成：</h4>
            <h4><b>規則：</b> 您可以指定期望的規則模板或者使用定制規則，選項有定制TCP規則、定制UDP規則或定制ICMP規則。</h4>
            <h4><b>打開端口/端口範圍：</b> 您選擇的TCP和UDP規則可能會打開一個或一組端口.選擇"端口範圍"，您需要提供開始和結束端口的範圍.對於ICMP規則您需要指定ICMP類型和代碼.</h4>
            <h4><b>遠程：</b> 您必須指定允許通過該規則的流量來源。可以通過以下兩種方式實現：IP地址塊(CIDR)或者來源地址組(安全組)。如果選擇一個安全組作為來訪源地址，則該安全組中的任何實例都被允許使用該規則訪問任一其它實例。</h4>
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
            { required: true, message: '請選擇打開端口!' },
          ],
          remoteType:[
            { required: true, message: '請選擇遠程!' },
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
          if(value=="port"){ //端口
            this.showPort = true;
            this.showPortRange = false;
          }else if(value=="portRange"){//端口範圍
            this.showPort = false;
            this.showPortRange = true;
          }else if(value=="allPort"){//所有端口
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
          }else if(value==2){//安全組
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