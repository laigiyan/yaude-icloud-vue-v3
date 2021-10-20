<template>
  <a-modal
    :title="title"
    :width="1000"
    :visible="visible"
    :confirmLoading="confirmLoading"
    @ok="handleOk"
    @cancel="handleCancel"
    cancelText="关闭">
    <a-spin :spinning="confirmLoading">
      <a-form-model ref="form"  :label-col="labelCol" :wrapper-col="wrapperCol"  :model="model" :rules="validatorRules">
        <a-row>
          <a-col :span="14" >
            <a-form-model-item label="規則" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="securityGroupRule">
              <j-dict-select-tag  :triggerChange="true" dictCode="security_group_rules"  v-model="model.securityGroupRule"  placeholder="请选择規則">
              </j-dict-select-tag>
            </a-form-model-item>

            <!--<a-form-model-item label="描述" :labelCol="labelCol" :wrapperCol="wrapperCol"  >
              <a-textarea v-model="model.description" placeholder="请输入描述" ></a-textarea>
            </a-form-model-item>-->

            <a-form-model-item label="方向" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="direction">
              <j-dict-select-tag  :triggerChange="true" dictCode="direction"  v-model="model.direction"  placeholder="请选择方向">
              </j-dict-select-tag>
            </a-form-model-item>

            <a-form-model-item label="打開端口" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="openPortType">
              <j-dict-select-tag  :triggerChange="true" dictCode="open_port_type"  v-model="model.openPortType" @change="changeOpenProtType"  placeholder="请选择端口管控方式">
              </j-dict-select-tag>
            </a-form-model-item>

            <a-form-model-item label="端口號" v-show="showPort"  :labelCol="labelCol" :wrapperCol="wrapperCol">
              <a-input placeholder="请输入端口號" v-model="model.port"></a-input>
            </a-form-model-item>

            <a-form-model-item label="起始端口號"  v-show="showPortRange" :labelCol="labelCol" :wrapperCol="wrapperCol">
              <a-input placeholder="请输入起始端口號"  v-model="model.portRangeMin"></a-input>
            </a-form-model-item>

            <a-form-model-item label="結束端口號" v-show="showPortRange" :labelCol="labelCol" :wrapperCol="wrapperCol">
              <a-input placeholder="请输入結束端口號" v-model="model.portRangeMax"></a-input>
            </a-form-model-item>


            <a-form-model-item label="遠程" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="remoteType">
              <j-dict-select-tag  :triggerChange="true" dictCode="remote_type" @change="changeRemoteType"  v-model="model.remoteType"  placeholder="请选择遠程">
              </j-dict-select-tag>
            </a-form-model-item>

            <a-form-model-item label="CIDR" v-show="showCIDR" :labelCol="labelCol" :wrapperCol="wrapperCol" >
              <a-input placeholder="请输入路由標記" v-model="model.cidr"></a-input>
            </a-form-model-item>

            <a-form-model-item label="安全組" v-show="showRemoteGroup" :labelCol="labelCol" :wrapperCol="wrapperCol">
              <a-select v-model="model.remoteGroupId"  placeholder="请选择安全組" >
                <a-select-option v-for="rgi in remoteGroupIds":value="rgi.value"  >{{rgi.text}}</a-select-option>
              </a-select>
            </a-form-model-item>

            <a-form-model-item label="以太網類型（EtherType）"  v-show="showRemoteGroup" :labelCol="labelCol" :wrapperCol="wrapperCol">
              <j-dict-select-tag  :triggerChange="true" dictCode="ether_type"  v-model="model.etherType"   placeholder="请选择端口管控方式">
              </j-dict-select-tag>
            </a-form-model-item>

          </a-col>

          <a-col :span="10" >
            <h1>説明</h1>
            <h4>实例可以关联安全组，组中的规则定义了允许哪些访问到达被关联的实例。安全组由以下三个主要组件组成：</h4>
            <h4><b>规则：</b> 您可以指定期望的规则模板或者使用定制规则，选项有定制TCP规则、定制UDP规则或定制ICMP规则。</h4>
            <h4><b>打开端口/端口范围：</b> 您选择的TCP和UDP规则可能会打开一个或一组端口.选择"端口范围"，您需要提供开始和结束端口的范围.对于ICMP规则您需要指定ICMP类型和代码.</h4>
            <h4><b>远程：</b> 您必须指定允许通过该规则的流量来源。可以通过以下两种方式实现：IP地址块(CIDR)或者来源地址组(安全组)。如果选择一个安全组作为来访源地址，则该安全组中的任何实例都被允许使用该规则访问任一其它实例。</h4>
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
      //表单禁用
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
            { required: true, message: '請选择规则!' },
          ],
          direction:[
            { required: true, message: '請选择方向!' },
          ],
          openPortType:[
            { required: true, message: '請选择打开端口!' },
          ],
          remoteType:[
            { required: true, message: '請选择遠程!' },
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
        // 触发表单验证
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
          }else if(value=="portRange"){//端口范围
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
          }else if(value==2){//安全组
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