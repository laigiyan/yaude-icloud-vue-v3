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


            <a-form-model-item label="遠程" :labelCol="labelCol" :wrapperCol="wrapperCol">
              <j-dict-select-tag  :triggerChange="true" dictCode="remote_type" @change="changeRemoteType"  v-model="model.remoteType"  placeholder="请选择遠程">
              </j-dict-select-tag>
            </a-form-model-item>

            <a-form-model-item label="CIDR" v-show="showCIDR" :labelCol="labelCol" :wrapperCol="wrapperCol">
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
            <a-form-model-item label="説明"  hasFeedback>
              <span>安全组是作用于虚拟机网络接口上的一组IP过滤规则。安全组创建完成后，你可以向其中添加规则。</span>
            </a-form-model-item>
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
          sm: { span: 17 },
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